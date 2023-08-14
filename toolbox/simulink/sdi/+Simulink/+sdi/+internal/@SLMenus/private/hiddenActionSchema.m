function schema=hiddenActionSchema(~,varargin)




    schema=sl_action_schema;
    schema.tag=varargin{1};
    schema.state='Hidden';
end
