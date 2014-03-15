$(document).ready(function() {
    for (var i in gallery) {
	var d = gallery[i];
	$('#gallery').append("<li class=\"gallery-thumb\">" +
	      "<a class=\"gallery-item\" href=\"" +
	      d.image +
	      "\"><img src=\"" +
	      d.thumb +
	      "\" border=0></a>" +
	      "</li>");
    }

    $('.gallery-item').magnificPopup({
	type: 'inline',
	items: gallery,
	inline: {
	    markup:
		"<div class=\"gallery-popup\">" +
		"<div class=\"mfp-image\"/>" +
		"<div class=\"mfp-text\"/>" +
		"</div>"
	},
	gallery: {
	    enabled: true
	}
    });
});

