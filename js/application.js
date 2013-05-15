var app = {
  setup: function() {
    var opts = ""
    for (var i = 0; i < dates.length; i++) {
      opts += "<option value=p_" + dates[i].replace(/-/g,"") + ">" + dates[i] + "</option>"
    }
    $("#date_picker").html(opts);

    $('#date_picker').change(function() {
      var show = $(this).val();
      var table_obj = $('#stats');
      table_obj.html("");
      for (var triple in show) {
           table_obj.append("<tr><td>"+triple+"</td><td>"+show[triple]+"</td></tr>");
      }
    });
  } 
};

$(function() {
  app.setup();
});



