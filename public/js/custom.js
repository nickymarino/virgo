$(document).ready(function () {
    // "Click" a link to a new wallpaper when submitting the form
    $('#wallpaper-form').on('submit', function(event) {
        // Don't redirect to a new page/request
        event.preventDefault();

        // Send a POST to get a new wallpaper link
        $.post('/gen-wallpaper?' + $('#wallpaper-form').serialize())
            .done(function(data) {
                // Create a downloadable link and click it in the background
                $('body').append('<a href="' + data + '" id="wall-link" download></a>');
                $('#wall-link')[0].click();
            });
    });

    // Update (remove) the delete button for the first foreground on load
    updateForegroundDeleteButtons();

    // Adds another foreground row to the form when clicked
    foregroundCounter = 0;
    $('#add-foreground-row').on('click', function() {
        if (foregroundCounter === 1) {
            $('.foreground-row').first().find('label').text('Foregrounds')
        }

        // Update the clone with an incremented id
        foregroundCounter++;
        createNewForegroundRow(foregroundCounter);

        updateForegroundDeleteButtons();
    });
})

// Deletes a foreground row based on the id, and updates the topmost
// foreground row label
function deleteForegroundId(id) {
    $(`#foreground-row-${id}`).remove();

    // Update the label of the topmost foregrond row
    var rows = $('.foreground-row');
    if (rows.length === 1) {
        var labelText = 'Foreground';
    } else {
        var labelText = 'Foregrounds';
    }
    rows.first().find('label').text(labelText);

    updateForegroundIds();
    updateForegroundDeleteButtons();
}

function updateForegroundIds() {
    foregroundCounter = 1;
    $.each($('.foreground-row'), function(index, row) {
        updateForegroundRowId($(row), index);
        foregroundCounter = index;
    });
}

function createNewForegroundRow(id) {
    // Copy the last foreground input row
    var oldRow = $('.foreground-row').last();
    var newRow = oldRow.clone();

    updateForegroundRowId(newRow, id);

    // Don't add another label for new rows, so make the text
    // blank to keep proper spacing
    newRow.find('label').text('')

    // Always enable the delete button since adding a row
    // means there are >1 foreground rows displayed
    newRow.find('.foreground-delete-btn').show();

    // Add the new row after the last foreground row
    newRow.insertAfter(oldRow);
}

function updateForegroundRowId(row, id) {
    row.attr('id', `foreground-row-${id}`);
    var label = `foreground${id}`
    row.find('label').attr('for', label);
    row.find('input').attr('id', label);
    row.find('input').attr('name', label);
    row.find('button').attr('onclick', `deleteForegroundId(${id})`);
}

// Hides/shows the delete button of the first foreground row
// if there are multiple foreground rows
function updateForegroundDeleteButtons() {
    var rows = $('.foreground-row');
    if (rows.length === 1) {
        rows.first().find('.foreground-delete-btn').hide();
    } else {
        rows.first().find('.foreground-delete-btn').show();
    }
}
