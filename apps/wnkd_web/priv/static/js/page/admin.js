;define(['jquery'], function($){
'use strict';
window.URL = window.URL || window.webkitURL;

$(document).ready(function(){

$( "#new-item" ).submit(function( event ) {
	var itemData = { images: {} };
	var formData = $( this ).serializeArray();
	for (var i = 0; i < formData.length; i++) {
		var value = formData[i];
		itemData[value.name] = value.value;
	}

	var fileList = $(this).find('.file-selector .file-input')[0].files;
	var files = [];
	for (var i = 0; i < fileList.length; i++) {
		files.push(fileList[i]);
	}
	var slurper = function(remainingFiles) {
		var file = remainingFiles.shift();
		if (file) {
			var reader  = new FileReader();
			reader.addEventListener("load", function () {
				itemData.images[file.name] = {
					data: arrayBufferToBase64(reader.result),
					type: file.type
				};
				slurper(remainingFiles);
			}, false);

			reader.readAsArrayBuffer(file);
		} else {
			$.post('api/item/new', JSON.stringify(itemData), function(){
				console.log('sent');
			}, 'json');
		}
	};
	slurper(files);
	event.preventDefault();
});

	var fileSelectors = $('.file-selector');

	fileSelectors.find('.file-input').on('change', function() {
		var files = this.files;
		var fileList = $(this).closest('.file-selector').find('.file-list');
		if (!files.length) {
			fileList.html("<p>No files selected!</p>");
		} else {
			fileList.empty();
			var list = $("<ul/>");
			fileList.append(list);
			for (var i = 0; i < files.length; i++) {
				var li = $("<li/>");
				list.append(li);

				var img = $("<img/>");
				img.attr('src', window.URL.createObjectURL(files[i]));
				img.addClass('thumbnail');
				img.on('load', function() {
					window.URL.revokeObjectURL(this.src);
				});
				li.append(img);
				var info = $("<span/>");
				info.html(files[i].name);
				li.append(info);
				var radio = $('<input/>');
				radio.attr('type', 'radio');
				radio.attr('name', 'primary');
				if (i === 0) {
					radio.attr('checked', 'checked');
				}
				radio.val(files[i].name);
				li.append(radio);
			}
		}
	});
	fileSelectors.find('.file-prompt').on('click', function(e) {
		$(this).closest('.file-selector').find('.file-input').click();
		e.preventDefault();
	});

});

function arrayBufferToBase64( buffer ) {
	var binary = '';
	var bytes = new Uint8Array( buffer );
	var len = bytes.byteLength;
	for (var i = 0; i < len; i++) {
		binary += String.fromCharCode( bytes[ i ] );
	}
	return window.btoa( binary );
}

});
