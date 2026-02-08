module PropertiesHelper
  def score_bar_color(score)
    score = score.to_f
    return '#2ecc71' if score >= 80
    return '#27ae60' if score >= 65
    return '#f39c12' if score >= 50
    return '#e67e22' if score >= 35
    '#e74c3c'
  end
end
