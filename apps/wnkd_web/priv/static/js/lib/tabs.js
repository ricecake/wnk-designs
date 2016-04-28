;define(['jquery'], function($){
'use strict';

$(document).ready(function(){
	$('.tabs .tab-links a').on('click', function(e)  {
		var currentAttrValue = $(this).attr('href');
		$('.tabs ' + currentAttrValue).fadeIn(400).siblings().hide();
		$(this).parent('li').addClass('active').siblings().removeClass('active');
		e.preventDefault();
	});
});

});
