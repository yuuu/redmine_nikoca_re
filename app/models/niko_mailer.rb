# Redmine_Nikoca_Re プラグイン NikoMailer
# @author yuuu(Yuhei Okazaki)

# ニコカレに関するメール送信を担う
# @abstract ニコカレに関するメール送信を担う
class NikoMailer < Mailer
  # レスポンス追加を通知する
  # @params face [NikoFace] レスポンス先の気分
  # @params res [NikoResponse] レスポンス
  def add_response(face, res)
    redmine_headers 'author' => res.author, 'owner' => face.author
    #message_id res
    #references face
    @niko_face = face
    #@niko_face_url = url_for(:controller => 'niko_face', :action => 'show', :id => face)
    mail(:to => face.author.mail, :cc => res.author.mail,
      :subject => "[Redmine_Nikoca_Re]add response to #{face.created_at.to_s} feeling.")
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
