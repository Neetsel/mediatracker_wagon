// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import Dropdown from "@stimulus-components/dropdown"
eagerLoadControllersFrom("controllers", application)

application.register('dropdown', Dropdown)
