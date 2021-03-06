require 'net/http'

module XiamiRadio
  class Downloader
    class << self
      def circulator
        @circulator ||= Queue.new
        %w(甲 乙).map(&@circulator.method(:push)) if @circulator.empty?
        @circulator
      end
    end

    attr_reader :track, :file

    def initialize(track)
      @track = track
    end

    def filename
      File.join XiamiRadio::TMP_DIR, self.class.circulator.pop(true)
    end

    def progress
      @progress.nil? ? 0.00 : (@progress.to_f / @total.to_f).round(2)
    end

    def start
      @thread ||= Thread.start { request URI(@track.location) }
    end

    def stop
      @thread&.exit
      @thread = nil
      File.delete(@file) if @file
    end

    private

    def request(uri)
      Net::HTTP.get_response uri do |res|
        if res.code == '302'
          request URI(res.header['Location'])
        else
          XiamiRadio.logger.info "#{@track.title} download start"
          @progress, @total = 0, res.header['Content-Length'].to_i
          @file = File.open(filename, 'w')
          res.read_body do |chunk|
            @file << chunk
            @progress += chunk.size
            @file.close unless @progress < @total
          end
        end
      end
      XiamiRadio.logger.info "#{@track.title} download completed"
    end
  end
end
