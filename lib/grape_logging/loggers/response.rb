module GrapeLogging
  module Loggers
    class Response < GrapeLogging::Loggers::Base
      require 'json'

      def parameters(_, response)
        response ? { response: serialized_response_body(response) } : {}
      end

      private

      # In some cases, response.body is not parseable by JSON.
      # For example, if you POST on a PUT endpoint, response.body is egal to """".
      # It's strange, but it's the Grape behavior...
      def serialized_response_body(response)
        body = response.respond_to?(:body) ? response.body : response

        if body.is_a?(Array)
          body.map { |chunk| serialize_chunk(chunk) }
        elsif body.is_a?(String)
          parse_json_or_fallback(body)
        elsif body.is_a?(Hash)
          body
        else
          body
        end
      end

      def serialize_chunk(chunk)
        return chunk if chunk.is_a?(Hash) || chunk.is_a?(Array)
        return parse_json_or_fallback(chunk) if chunk.is_a?(String)

        parse_json_or_fallback(chunk.to_s)
      end

      def parse_json_or_fallback(string)
        JSON.parse(string)
      rescue JSON::ParserError, TypeError
        string
      end
    end
  end
end
