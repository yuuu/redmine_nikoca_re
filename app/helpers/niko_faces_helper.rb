module NikoFacesHelper
  def link_comment_face_tag(project, face)
    if face != nil
      img_src = content_tag(:span) do
        link_to(feeling_tag(face.feeling), project_niko_face_path(@project, face.id))
      end
      comment_src = content_tag(:div, :class => 'arrow_box') do
        concat(face.comment != '' ? face.comment : l(:no_comment))
        if !face.responses.empty?
          concat(tag(:br))
          resnum_src = content_tag(:span, :class => "responseinfo") do
            concat("#{l(:field_comment)}: #{face.responses.size}#{l(:comment_unit)}")
          end
          concat(resnum_src)
        end
      end
      return concat(img_src + comment_src)
    else
      return concat(feeling_tag(nil))
    end
  end

  def feeling_tag(feeling)
    options = {:plugin => 'redmine_nikoca_re', :width => '32', :height => '32'}

    if feeling != nil
      icon = ({1 => 'good.png', 2 => 'normal.png', 3 => 'bad.png'}[feeling])
      label = ({1 => :good, 2 => :normal, 3 => :bad}[feeling])
      options[:alt] = l(label)
      image_tag(icon, options)
    else
      options[:alt] = l(:none)
      image_tag('none.png', options)
    end
  end

  def date_tag(date, is_topday)
    if date.day == 1
      date_s = date.month.to_s + "/" + date.day.to_s
    elsif is_topday
      date_s = date.month.to_s + "/" + date.day.to_s
    else
      date_s = date.day.to_s
    end

    if date.wday == 0
      s = content_tag(:th, :class => 'sunday') do
        concat(date_s)
      end
    elsif date.wday == 6
      s = content_tag(:th, :class => 'saturday') do
        concat(date_s)
      end
    else
      s = content_tag(:th) do
        concat(date_s)
      end
    end
    concat(s)
  end
end
