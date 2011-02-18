!Using gik-animated-callout

Gik-animated-callout is a set of classes that reproduces the callouts and animations of the iPad maps app. It uses only the available publie classes.

1. The mapView gets its data from a .plist, consisting of location information for hotels in San Francisco.

2. For each Hotel object, a HotelAnnotation (subclass of GIKAnnotation) is added to the map.

3. Pin annotationViews are instances of GIKPinAnnotationView (subclass of MKPinAnnotationView).
GIKPinAnnotationView has a BOOL property which is used to prevent an annotation from being deselected. MKMapView is "greedy" when it comes to touches; any touch intercepted forces a selected annotation to be deselected. We need to intercept that behaviour.

4. If a pin is selected, a second annotation, GIKCallout, is added to the map at the same coordinates as the parent annotation. That annotation will be deletede as seoon as the user 
taps outside of the callout, or when taping inside the contentview of the final CalloutView.
Its associated annotationView is an instance of GIKCalloutView.
GIKCalloutView is our custom bubble annotation view.

5. GIKCalloutView handles the layout and animation of its subviews.
There are 15 subviews for the "bubble" itself.
When the accessory button is pressed, the callout's arrows (facing down and left/right) are drawn from a series of 15 frames. The animation of these frames are handled by a CADisplayLink added to the animation block.

6. GIKCalloutContentView is where the bubble's text label, accessory button, and detail view are defined.

7. We're using UIGestureRecognizers for the right accessory and on the detail table view instead of hit testing on views and handling touches with touchesBegan: touchesMoved: etc.


!License

gik-animated-callout is licensed under the terms of the BSD License. Please refer to Gik as Geeks in Kilt in the attribution.

