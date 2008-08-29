// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function makeMove(cell,game_id,player_tag,player_id) {
	$.ajax({ 
		type: 'PUT',
		dataType: 'json',
		url: '/games/' + game_id +'?player_id=' + player_id + '&row=' + cell.data('go_row') + '&col=' + cell.data('go_col'),
		error: function(XMLHttpRequest, textStatus, errorThrown) {
			alert(XMLHttpRequest.responseText);
			// $('#server_message').html(textStatus)
			// $('#server_message').dialog({autoOpen:true, position:'center', title: 'Go Server Says:'})
		},
		success: function(data,textStatus) {
			cell.children('.piece_image').addClass(player_tag + '_piece');
			$(".played_marker").removeClass('played_marker_active');
			cell.children(".played_marker").addClass('played_marker_active');
			$("div[display_key='whose_turn']").toggle();
			checkForMove(game_id,player_tag,player_id);
			for (key in data) {
				if (data[key].col >= 0){
					$('#cell_' + data[key].col + '_' + data[key].row).children('.piece_image').removeClass(opponentTag(player_tag) + '_piece');
				}
			}
		}
	})
}

function preloadPosition(cell,player_tag,last_played){
	// cell.html( '<img src="/images/' + player_tag + '_stone.png" style="position: absolute;">');
	cell.children('.piece_image').addClass(player_tag + '_piece');
	if(last_played == true){
		cell.children('.played_marker').addClass('played_marker_active');
	}
}
function checkForMove(game_id,player_tag,player_id){
	$.ajax({
		type: 'GET',
		dataType: 'json',
		url: '/games/' + game_id +'?player_id=' + player_id + '&polling_for_turn=true',
		error: function(XMLHttpRequest, textStatus, errorThrown) {
			_timeout = setTimeout(function(){checkForMove(game_id, player_tag, player_id)},1000);
		},
		success: function(data,textStatus) {
			if( data.played != null ) {
				$("div[display_key='whose_turn']").toggle();
				cell_id = '#cell_' + data.played.col + '_' + data.played.row;
				$(".played_marker").removeClass('played_marker_active');
				$(cell_id).children(".played_marker").addClass('played_marker_active');
      	$(cell_id).children(".piece_image").addClass( opponentTag(player_tag) + '_piece');
				for (key in data.captured) {
					$('#cell_' + data.captured[key].col + '_' + data.captured[key].row).children('.piece_image').removeClass(player_tag + '_piece');
				}
			}
		}
	})
}

function opponentTag(player_tag) {
	switch (player_tag) {
		case 'white':
			return 'black';
			break;
		case 'black':
			return 'white';
			break;
	}
}