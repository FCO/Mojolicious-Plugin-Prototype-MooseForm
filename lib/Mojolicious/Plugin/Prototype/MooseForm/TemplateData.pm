package Mojolicious::Plugin::Prototype::MooseForm::TemplateData;
use Moose;
42

__DATA__

@@ moose_form_template_say_required_default.html.ep
<span class=required></span>

@@ moose_form_template_say_required_1.html.ep
<span class=required>*</span>

@@ moose_form_template_change_type_arrayref.html.ep
% $$required = 0;
% my $array_req = 1;
<div class="array_item_base submit_remove">
   <div class=item>
      <%= include moose_form_template_for( "change", "type", $subtype ), attr => $attr, type => $subtype, required => \$array_req =%>
      <%= include moose_form_template_for( "say", "required", $array_req ), attr => $attr =%>
      <input class=remove type=button value="-"><br>
   </div>
</div>
<div class=array_active>
   % my $counter = 0;
   % my $orig_name = $attr->{ name };
   % for my $val(@{ $attr->{ value } }) {
      % $counter++;
      % $attr->{ value } = $val;
      % $attr->{ name } = $orig_name . $counter;
      <div class=item>
         <%= include moose_form_template_for( "change", "type", $subtype ), attr => $attr, type => $subtype, required => \$array_req =%>
         <%= include moose_form_template_for( "say", "required", $array_req ), attr => $attr =%>
         <input class=remove type=button value="-"><br>
      </div>
   % }
</div>

<input class=add type=button value="+" count="<%= $counter =%>">

@@ moose_form_template_change_type_any.html.ep
% $$required = 0;
<%= include "moose_form_template_change_type_default", attr => $attr, type => $subtype, required => $required =%>

@@ moose_form_template_change_type_maybe.html.ep
% $$required = 0;
<%= include moose_form_template_for( "change", "type", $subtype ), attr => $attr, type => $subtype, required => $required =%>

@@ moose_form_template_change_type_default.html.ep
<input
 class="attr_input type_<%= join " ", lc($type ? $type : $attr->{ type }), $$required ? "inp_required" : () =%>"
 type="text"
 name="<%= $attr->{ name }  =%>"
 value="<%= $attr->{ value }  =%>"
>

@@ moose_form.html.ep
<link rel="stylesheet" type="text/css" href="<%= url_for "/css/moose_form.css" =%>" />
<script src="<%= url_for "js/jquery.js" =%>"></script>
<script src="<%= url_for "js/main.js" =%>"></script>
<form class="moose_form_<%= $class =%>" method=POST action="<%= $action =%>?rand=<%= rand =%>">
   <% if($attributes) { =%>
      <%= include "moose_form_table", attributes => $attributes =%>
   <% } =%>
</form>

@@ moose_form_table.html.ep
% my $num_of_colors = scalar @{ moose_form_get_conf()->{prototype_list_bgcolor} };
<table class=moose_form_table>
% my $counter = 0;
% for my $attr(sort {$a->{ name } cmp $b->{ name }} @$attributes) {
   <tr class="bgcolor_<%= ( $counter++ % $num_of_colors ) + 1 %>">
   %= include "moose_form_line", attr => $attr;
   </tr>
% }
   <tr class="bgcolor_<%= ( $counter++ % $num_of_colors ) + 1 %>">
   %= include "moose_form_last_line";
   </tr>
</table>

@@ moose_form_last_line.html.ep
% my $value = moose_form_get_conf()->{prototype_submit_label};
<td colspan=2 align=right>
   <input type=submit value="<%= $value =%>"
</td>

@@ moose_form_line.html.ep
% my $required = 1;
<td>
   <%= include moose_form_template_for( "title", "none", "bla" ), attr => $attr =%>
</td>
<td>
   <%= include moose_form_template_for( "change", "type", $attr->{ type } ), attr => $attr, type => $attr->{  type } , required => \$required =%>
   <%= include moose_form_template_for( "say", "required", $required ), attr => $attr =%>
   <div
    class=error_msg
    <% if($error->{$attr->{name}}) { =%>
       style="display: block;"
    <% } =%>
   >
      <% if( $attr->{ doc } ) { =%>
         <%= $attr->{ doc } =%>
      <% } else { =%>
         <%= moose_form_get_conf()->{prototype_default_error_msg} =%>
      <% } =%>
      <% if($error->{$attr->{name}}) { =%>
         <BR>
         <strong>ERROR:</strong> <%= $error->{$attr->{name}} =%>
      <% } =%>
      </div>
</td>

@@ moose_form_template_title_none_default.html.ep
<span class="attr_line_header"><%= $attr->{ name } =%></span>

@@ moose_form.css.ep
% my $conf = moose_form_get_conf();
% my @colors = @{ $conf->{prototype_list_bgcolor} };
% for( my $index = 0; $index < @colors; $index++) { 
.bgcolor_<%= $index + 1 =%> {
   background-color: <%= $colors[ $index ] =%>;
} 
% }
.moose_form_table {
  width: 100%;
}
.required {
   color: <%= $conf->{ prototype_required_color } =%>;
}
.error_msg {
   border:
      <%= $conf->{ prototype_error_border_width } =%>
      solid
      <%= $conf->{ prototype_error_border_color } =%>;
   background-color: <%= $conf->{ prototype_error_bgcolor } =%>;
   padding: 3px;
   display: none;
}
input.input_error {
   color: <%= $conf->{ prototype_input_error_color } =%>; 
}
div.array_item_base {
   display: none;
}

@@ js/main.js

$(document).ready(function(){
   $(".array_item_base input[type!='button']").val( "" );
   $(".attr_input").each(function(){
      this.array_test = [];
      this.gotwrong = function(){ 
         $(this).parents("td").find(".error_msg").show("slow");
         $(this).focus();
         $(this).addClass("input_error");
      };
      this.gotright = function(){ 
         $(this).parents("td").find(".error_msg").hide("slow");
         $(this).removeClass("input_error");
      };
   });
   $(".attr_input").change(function(){
      var array_test = this.array_test;
      var resp = true;
      for(var i = 0; i < array_test.length; i++)
         resp = resp && array_test[i](this);
      if(resp)
         this.gotright();
      else
         this.gotwrong();
   });
   $(".type_num").each(function(){
      this.array_test.push(function(obj){return $(obj).val().match(/^[+-]?\d*(?:.\d+)?$/)});
   });
   $(".inp_required").each(function(){
      this.array_test.push(function(obj){return $(obj).val() != ""});
   });
   $(".add").click(function(){
      $(this).attr("count", parseInt($(this).attr("count")) + 1);
      var new_item = $(this).parents("td").find(".array_item_base div").clone();
      new_item.hide();
      $(new_item).find("input[type!='button']").attr(
         "name", $(new_item).find("input").attr("name") + $(this).attr("count")
      );
      $(this).parents("td").find(".array_active").append( new_item );
      new_item.show("slow", function(){
         new_item.find("input[type!='button']").first().focus();
      });
   });
   $(".array_active input.remove").live("click", function(){
      var iname = $(this).parents(".item").find(".attr_input").attr("name");
      $(this).parents(".item").hide( "slow", function(){ $(this).remove() });
      var add = $(this).parents("td").find(".add");
      add.attr("count", parseInt(add.attr("count")) - 1);

      $(this).parents(".item").nextAll(".item").each(function(){
         var tmpname = $(this).find(".attr_input").attr("name");
         $(this).find(".attr_input").attr("name", iname);
         iname = tmpname;
      });
   });
   $("form.moose_form").submit(function(){
      $(this).find(".submit_remove").remove();
   });
});






