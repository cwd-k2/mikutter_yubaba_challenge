Plugin.create(:mikutter_yubaba_challenge) do
  UserConfig[:yubaba_challenge_default_name] ||= 'mikutterユーザ'
  UserConfig[:yubaba_challenge_update_profile]  ||= false

  command(:yubaba_challenge,
          name: _('湯婆婆命名チャレンジ'),
          condition: lambda { |opt| true },
          visible: true,
          role: :postbox) do |_|
    post_n_update
  end

  def challenge_shindan
    https = Net::HTTP.new('shindanmaker.com', 443)
    https.use_ssl = true
    res = https.post("/696416", "u=#{UserConfig[:yubaba_challenge_default_name]}")
    doc = Nokogiri::HTML.parse(res.body)
    return doc.xpath('//textarea').first.inner_text
  end

  def post_n_update
    text = challenge_shindan
    name = text[/返事をするんだ、(.*?)！/, 1]
    world, = Plugin.filtering(:world_current, nil)
    update_profile_name(world, name: name) if UserConfig[:yubaba_challenge_update_profile]
    compose(world, body: text)
  end

  settings("湯婆婆命名チャレンジ") do
    input("贅沢な名前", :yubaba_challenge_default_name)
    boolean("投稿時にユーザ名を更新", :yubaba_challenge_update_profile)
  end
end
