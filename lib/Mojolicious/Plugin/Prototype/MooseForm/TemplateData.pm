package Mojolicious::Plugin::Prototype::MooseForm::TemplateData;
use Moose;
42

__DATA__

@@ moose_form_template_say_required_default.html.ep
<span class=required></span>

@@ moose_form_template_say_required_1.html.ep
<span class=required>*</span>

@@ moose_form_template_change_type_maybe.html.ep
% $$required = 0;
<%= include moose_form_template_for( "change", "type", $subtype ), attr => $attr, type => "default", required => $required =%>

@@ moose_form_template_change_type_default.html.ep
<input
 class="attr_input type_<%= lc $attr->{ type } =%>"
 type="text"
 name="<%= $attr->{ name }  =%>"
 value="<%= $attr->{ value }  =%>"
>

@@ moose_form.html.ep
<link rel="stylesheet" type="text/css" href="<%= url_for "/css/moose_form.css" =%>" />
<script src="<%= url_for "js/jquery.js" =%>"></script>
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
   <%= include moose_form_template_for( "change", "type", $attr->{ type } ), attr => $attr, type => "default", required => \$required =%>
   <%= include moose_form_template_for( "say", "required", $required ), attr => $attr =%>
   <% if( $attr->{ doc } ) { =%>
      <div
       class=error_msg
       <% if($error->{$attr->{name}}) { =%>
          style="display: block;"
       <% } =%>
      >
         <%= $attr->{ doc } =%>
         <% if($error->{$attr->{name}}) { =%>
            <BR>
            <%= $error->{$attr->{name}} =%>
         <% } =%>
      </div>
   <% } =%>
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


