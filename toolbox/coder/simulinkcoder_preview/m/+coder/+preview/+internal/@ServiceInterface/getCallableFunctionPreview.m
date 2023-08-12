function out = getCallableFunctionPreview( obj, namingRule, body, options )


R36
obj
namingRule
body
options.MemorySection = [  ]
options.BodyTooltip = {  }
end 



prototype = obj.getFunctionPrototype( 'void', obj.getFunctionName( namingRule ) );
indent = '&nbsp;&nbsp;';


memorySectionComment = [  ];
preStatement = [  ];
postStatement = [  ];
if ~isempty( options.MemorySection )
if ~isempty( options.MemorySection.Comment )
memorySectionComment = obj.getComment( options.MemorySection.Comment );
end 
if ~isempty( options.MemorySection.PreStatement )
preStatement = options.MemorySection.PreStatement;
end 
if ~isempty( options.MemorySection.PostStatement )
postStatement = options.MemorySection.PostStatement;
end 
end 


bodyTooltip = options.BodyTooltip;
if ~isempty( bodyTooltip ) && ~isempty( body )
if iscell( bodyTooltip )
bodyTooltip = strjoin( bodyTooltip, '&#10;' );
end 
body{ 1 } = [ sprintf( '<span title="%s">', bodyTooltip ), body{ 1 } ];
body{ end  } = [ body{ end  }, '</span>' ];
end 


code = [ 
memorySectionComment
preStatement
prototype
'{'
strcat( indent, body );
'}'
postStatement
 ];

out = obj.getPreviewCodeDiv( sprintf( '%s\n', code{ : } ) );

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6UQh9G.p.
% Please follow local copyright laws when handling this file.

