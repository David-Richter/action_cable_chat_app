App.property = App.cable.subscriptions.create "PropertyChannel",
  connected: ->
    console.log "Property channel connected"

  disconnected: ->
    console.log "Property channel disconnected"

  received: (data) ->
    if data.type == 'new_recommendations'
      @showNotification(data)

  showNotification: (data) ->
    notification = document.createElement('div')
    notification.className = 'property-notification'
    top_prop = data.top_property
    notification.innerHTML = """
      <div class="notification-content">
        <strong>#{data.count} neue Empfehlung(en)!</strong>
        <p>Top: #{top_prop.title} - Score: #{top_prop.score} - #{top_prop.price}</p>
        <a href="/properties/#{top_prop.id}">Ansehen</a>
      </div>
    """
    document.body.appendChild(notification)
    setTimeout ->
      notification.classList.add('fade-out')
      setTimeout ->
        notification.remove()
      , 500
    , 8000
