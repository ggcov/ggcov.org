
var pages;
var delay = 3000;

function show_next()
{
    var next = pages.next();
    if (next.length) {
	pages.hide();
	pages = next;
	pages.show();
	window.setTimeout(show_next, delay);
    }
}

$(document).ready(function() {
    /* On FF the formatting screws up if this button
     * is hidden by default and then shown in JS */
    if (navigator.userAgent.indexOf('Ubuntu;') < 0)
	$('#front #curious #ubuntu').hide();

    pages = $('#front .cloud');
    pages.css('margin-left', (Math.max(0, ($(window).width() - pages.first().outerWidth())) / 2) + "px");
    pages = pages.first();
    pages.show();
    window.setTimeout(show_next, delay);
});
