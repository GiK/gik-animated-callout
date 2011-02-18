GIKAnimatedCallout
==================

GIKAnimatedCallout demonstrates the use of an `MKAnnotationView` subclass to provide functionality similar to the callouts in Maps.app on iPad.

---
Note
----

The project will build and run on an iPad running a minimum of iOS 4.2.

It is not intended to run as-is on an iPhone or iPod touch. I recommend sticking with Apple's approach of handling callouts on those devices. That being said, parts of `GIKCalloutView` could be canabalised to provide a variable-height callout on smaller iOS devices if needed.

---
Background
----------

Maps.app on iPad is an example of Apple keeping the good APIs for themselves. If you've used it, you're certain to have seen the default callout bubble slide to the side of a selected pin and then expand to reveal a `UITableView` embedded within. Not only that, but the arrow that points to the pin animates once you've selected the accessory button:

- the initial down arrow appears to shrink into the callout bubble
- an arrow pointing left or right appears to grow out of the expanded callout

Keeping the detail table anchored to the pin is a great user experience. And it's all done using private API.

This project is my attempt to reproduce that functionality using publicly available API.

Portions of [James Rantanen's][ref] work on custom map annotations were adapted for this project, specifically using a second `MKAnnotation` object and `MKAnnotationView` to display the custom callout bubble.

  [ref]: http://blog.asolutions.com/2010/09/building-custom-map-annotation-callouts-part-1/


---
Packing List
------------

*	`GIKMapViewController`

	`UIViewController` subclass which implements `MKMapViewDelegate`. File's Owner for `GIKMapView.xib`. Subclass this in your own map controller and adopt the data source protocol, `GIKCalloutDetailDataSource`.

	In your subclass of `GIKMapViewController`, override the `-init` method to call `super`'s `-initWithNibName:bundle:`, providing `GIKMapView` as the nib name.

	The delegate method `-detailController:detailForAnnotation:` is used to set the data object of your detail view controller (in this example, `HotelDetailViewController`).


*	`GIKAnnotation`

	In `MapKit`, each pin object is backed by an annotation and an annotation view. An annotation is an invisible marker which corresponds to a latitude and longitude on the map. The annotation view is the visual representation of that marker, typically that of a pin.

	Your annotation objects which will display a custom callout should subclass `GIKAnnotation`.

	`GIKAnnotationView` and `GIKPinAnnotationView` are `GIKAnnotation`'s corresponding annotation views.

	In this sample project, `HotelAnnotation` subclasses `GIKAnnotation`. The `title` property is overridden to return the hotel's name.


*	`GIKPinAnnotationView`

	Subclass of `MKPinAnnotationView` used to provide a standard pin icon.

	If a map view detects a touch which isn't with the bounds of an `MKAnnotationView`, the currently selected annotation view will be deselected and its callout dismissed. The `selectionEnabled` property is used to allow or prevent the map view from deselecting the pin annotation view. This is important when touches are detected on the custom callout annotation view.


*	`GIKAnnotationView`

	Subclass of `MKAnnotationView` which can display a custom image instead of a standard pin icon and has a property called `selectionEnabled` to manage the selection state of the annotation view.


*	`GIKCalloutAnnotation`

	When the user taps a pin, the default behaviour is to show a callout bubble (if `canShowCallout` is `YES`). There is no public API to allow customisation of the standard callout bubble beyond setting the `leftCalloutAccessoryView` and `rightCalloutAccessoryView` properties in `MKAnnotationView`. Therefore, an instance of `GIKCalloutAnnotation` is added to the map at the same coordinates as the selected pin, and it's this that's used to anchor the custom view to the pin.

	When the map view asks its delegate to provide an annotation view for `GIKCalloutAnnotation`, it's given an instance of `GIKCalloutView`.


*	`GIKCalloutView`

	Subclass of `MKAnnotationView` which represents the callout bubble. It has two states:

	1.  `CalloutModeDefault` has the same appearance as a standard map callout.
	2.  `CalloutModeDetail` has the same appearance as the custom callout in Maps.app on iPad.

	The `calloutContentView` property is the container view for the callout, which is defined in `GIKCalloutContentView`. The content view is assigned in `GIKMapViewController`'s `MKMapViewDelegate` method `mapView:viewForAnnotation:`.

	Adopts the `GIKCalloutContentViewDelegate` protocol, used to receive messages related to `UIGestureRecognizer` touch events sent from the content view.


*	`GIKCalloutContentView`

	A simple `UIView` subclass which comprises the label, accessory view(s), and detail view subviews of `GIKCalloutView`.

	Declares the `GIKCalloutContentViewDelegate` protocol to notify the callout view of certain `UIGestureRecognizer` touch events.


---
In Use
------

Create a subclass of `GIKMapViewController`. Adopt the `GIKCalloutDetailDataSource` protocol.

In the `detailController:detailForAnnotation:` delegate method, provide a data object from your model which will be displayed in the detail controller. See the sample `MapViewController` for an example.

In the sample, `HotelDetailViewController` is a view controller whose `UITableView` is added to `GIKCalloutContentView` detail view.

Finally, create a subclass of `GIKAnnotation` which will be the `MKAnnotation` tied to a pin icon. In the sample, `HotelAnnotation` has a `hotel` instance variable. This is assigned in `MapViewController`'s `showAnnotations` method - when annotations are added to the map view.


---
//TODO:
-------

*	`GIKCalloutView`

	Add a method to adjust the map's on-screen region when a callout is drawn outside the bounds of the map. I have this in a project I'm working on at the moment, but it needs some work.
	
*	`GIKCalloutContentView`

	Add a left accessory view and subtext label.
	
*	General

	Fix some issues with touch handling on the sample's table view.
	
	Attempting to scroll the table view in the simulator just plain up doesn't work, and will result in the parent annotation view being deselected. It seems that the simulator interprets any gesture as a tap.
	
	Test different detail controllers, such as tiled scrollview, image browser, etc.
	

---
Contact
-------

Twitter: [@gordonhughes](http://twitter.com/gordonhughes)