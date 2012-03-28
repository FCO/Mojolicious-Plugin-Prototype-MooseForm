package Mojolicious::Plugin::Prototype::MooseForm::TemplateData;
use Moose;
42

__DATA__

@@ js_onchange_for_type_num.html.ep
onchange="if( !this.value.match(/^\d*$/) ){alert('error!!!')}"
@@ js_onchange_for_type_default.html.ep
onchange="ble"
@@ js_event_for.html.ep
<%= include js_event_for($event, $what, $value), attr => $attr; =%>
@@ template_for_type_default.html.ep
<input
 class="attr_input type_<%= $type =%>"
 type="text"
 name="<%= $attr->{ name }  =%>"
 value="<%= $attr->{ value }  =%>"
 <%= include "js_event_for", event => "onchange", what => "type", value => $type =%>
>

@@ template_for_type.html.ep
%= include template_for_type($attr->{ type }), attr => $attr, type => "default" 

@@ template_for_type_num.html.ep
<%= include "template_for_type_default", attr => $attr, type => "num" =%>

@@ moose_form.html.ep

<script src="<%= url_for "js/jquery.js" =%>"></script>
<form class="moose_form <%= $class =%>">
   <% if($attributes) { =%>
      <%= include "class_attr_iterator", attributes => $attributes =%>
   <% } =%>
</form>

@@ class_attr_iterator.html.ep
<table>
% for my $attr(@$attributes) {
   <tr>
   %= include "attr_line", attr => $attr;
   </tr>
% }
</table>

@@ attr_line.html.ep
<td><%= include "attr_line_header", attr => $attr =%></td>
<td><%= include "template_for_type", attr => $attr =%></td>

@@ attr_line_header.html.ep
<span class="attr_line_header"><%= $attr->{ name } =%></span>
