{% macro trimmer(column_namea) %}
    {{ column_name | trim | upper }}
{% endmacro %}
