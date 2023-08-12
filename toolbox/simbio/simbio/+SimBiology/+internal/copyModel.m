function modelOut = copyModel( modelIn )













R36
modelIn( 1, 1 )SimBiology.Model{ SimBiology.internal.mustBeValidModel }
end 


bytes = SimBiology.internal.serialize( modelIn );
modelOut = SimBiology.internal.deserialize( bytes );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgpl2lA.p.
% Please follow local copyright laws when handling this file.

