class WebController < Rubot::Controller
  listener matches: %r{http://[^\s]+} do
    reply WebUtil.title(matches)
  end
end
