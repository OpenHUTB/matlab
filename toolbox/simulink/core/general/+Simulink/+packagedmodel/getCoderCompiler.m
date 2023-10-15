function result = getCoderCompiler( model )

arguments
    model{ mustBeTextScalar, mustBeNonempty }
end

allowLCC = true;
defaultCompInfo = coder.internal.DefaultCompInfo.createDefaultCompInfo(  );
modelCompInfo = coder.internal.ModelCompInfo.createModelCompInfo(  ...
    model, defaultCompInfo.DefaultMexCompInfo, allowLCC );

result = Simulink.packagedmodel.getCoderCompilerFromCompInfo( modelCompInfo );
end
