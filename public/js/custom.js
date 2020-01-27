$(document).ready(function () {
    $('#wallpaper-form').on('submit', function(event) {
        event.preventDefault();
        $.post('/gen-wallpaper?' + $('#wallpaper-form').serialize())
            .done(function(data) {
                $('body').append('<a href="' + data + '" id="wall-link" download></a>');
                $('#wall-link')[0].click();
            });
    });
})
