require 'slack-ruby-bot'

SlackRubyBot.configure do |config|
  config.send_gifs = false
end

class TkBot < SlackRubyBot::Bot
  RETORT_URL = 'http://www.retort.us'

  # Imitate people by medium
  match /\@?TK:? be someone from (?<medium>.+)$/i do |client, data, match|
    response = retort_for(medium: match['medium'])
    client.say(channel: data.channel, text: response)
  end

  # Imitate people by name
  match /\@?TK:? be (?<person>[^\s]+)/i do |client, data, match|
    # src = "#{retort_url}/markov/create?identifier=#{person}&medium=irc.amazdong.com&channel=interns"
    # uri = URI.parse(src)
    # http = Net::HTTP.new(uri.host, uri.port)

    # request = Net::HTTP::Get.new(uri.request_uri)
    # response = http.request(request)

    # m.reply response.body

    client.say(channel: data.channel, text: "Imitating #{match['person']}")
  end

  # Preach it
  match /preach/i do |client, data, match|
    client.say(channel: data.channel, text: "Preach it")
  end

  # Learn from all messages
  match /(?<text>.+)/ do |client, data, match|
    # match anything, feed to retort
    # TODO: get real identifier here, not 9 character hash
    #feed_retort(message: data['text'], identifier: data['user'], channel: data['channel'], medium: "#{data['team']@Slack}")
    #client.say(channel: data.channel, text: data['user']['id'].inspect)
  end

  private

  def self.retort_for identifier: nil, channel: nil, medium: nil
    id_params = build_id_params(identifier: identifier, channel: channel, medium: medium)

    src  = "#{RETORT_URL}/markov/create?#{id_params.join('&')}"
    uri  = URI.parse(src)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    response.body.force_encoding('ISO-8859-1')
  #rescue
  #  "no u"
  end

  def self.feed_retort message:, identifier: nil, channel: nil, medium: nil
    id_params = build_id_params(identifier: identifier, channel: channel, medium: medium)
    src  = "#{RETORT_URL}/markov/parse?message=#{message}&#{id_params.join('&')}"

    uri  = URI.parse(src)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  end

  def self.build_id_params identifier: nil, channel: nil, medium: nil
    id_params = []
    id_params << "identifier=#{identifier}" if identifier
    id_params << "channel=#{channel}"       if channel
    id_params << "medium=#{medium}"         if medium
    id_params
  end

end

TkBot.run
