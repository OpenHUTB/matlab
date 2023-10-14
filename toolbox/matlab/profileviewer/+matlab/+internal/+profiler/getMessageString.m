function msgStr = getMessageString( messageId )

arguments
    messageId{ mustBeTextScalar }
end

msgStr = getString( message( messageId ) );
end

