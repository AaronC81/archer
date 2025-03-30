/**
 * Details about the properties of a target.
 * 
 * Properties are defined by the JSON returned from the server. This provides some helper methods
 * for that data.
 */
export default class TargetDetails {
    constructor(obj) {
        Object.assign(this, obj)
    }
}
