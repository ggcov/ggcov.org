$(document).ready(function() {
    /* On FF the formatting screws up if this button
     * is hidden by default and then shown in JS */
    if (navigator.userAgent.indexOf('Ubuntu;') < 0)
	$('#front #ubuntu').hide();
});
