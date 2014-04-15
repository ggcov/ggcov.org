$(document).ready(function()
{
    var insts = $('#download h3');
    insts.click(function() {
	$(this).next().toggle('medium');
	location.hash = '#' + $('a', this).prop('name');
	return false;
    });
    insts.next().hide();
    if (location.hash)
    {
	$('#download h3 a[href="' + location.hash + '"]').parent().next().show();
    }
});
