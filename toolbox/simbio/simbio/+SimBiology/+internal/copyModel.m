function modelOut = copyModel( modelIn )

arguments
    modelIn( 1, 1 )SimBiology.Model{ SimBiology.internal.mustBeValidModel }
end

bytes = SimBiology.internal.serialize( modelIn );
modelOut = SimBiology.internal.deserialize( bytes );
end
