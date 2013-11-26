# For more information see: http://emberjs.com/guides/routing/
Revily.Router.reopen
  location: "history"
  
Revily.Router.map ->
  @route "sink"
  @route "login"
    
  @resource "dashboard", path: "/"
  @resource "services", ->
    @route "ok"
    @route "warning"
    @route "critical"
    # @route "enabled"
    # @route "disabled"
    @route "show", path: ":id"
  @resource "incidents", ->
    @route "show", path: ":id"
  @resource "policies", ->
    @route "show", path: ":id"
  @resource "schedules", ->
    @route "show", path: ":id"
  @resource "users", ->
    @route "show", path: ":id"
  @resource "events", ->
    @route "show", path: ":id"
