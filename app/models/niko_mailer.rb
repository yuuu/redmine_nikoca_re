# Redmine_Nikoca_Re プラグイン NikoMailer
# @author yuuu(Yuhei Okazaki)

# ニコカレに関するメール送信を担う
# @abstract ニコカレに関するメール送信を担う
class NikoMailer < Mailer
  # レスポンス追加を通知する
  # @params face [NikoFace] レスポンス先の気分
  # @params res [NikoResponse] レスポンス
  def add_response(current_user, project, face, res)
    redmine_headers 'author' => res.author, 'owner' => face.author
    #message_id res
    #references face
    @project = project
    @niko_face = face
    @niko_res = res

    cc_list = Array.new
    face.responses.each do |response|
      cc_list << response.author.mail
    end
    cc_list.uniq!
    cc_list.delete(res.author.mail)

    mail(:to => face.author.mail, :cc => cc_list, :subject => "[Redmine_Nikoca_Re]add response to #{face.created_at.strftime("%Y-%m-%d")} feeling.")
  end

  def self.method_missing(method, *args, &block)
    if m = method.to_s.match(%r{^deliver_(.+)$})
      ActiveSupport::Deprecation.warn "NikoMailer.deliver_#{m[1]}(*args) is deprecated. Use NikoMailer.#{m[1]}(*args).deliver instead."
      send(m[1], *args).deliver
    else
      super
    end
  end
end
