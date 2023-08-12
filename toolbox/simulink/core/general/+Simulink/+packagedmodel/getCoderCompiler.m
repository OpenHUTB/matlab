function result = getCoderCompiler( model )




R36
model{ mustBeTextScalar, mustBeNonempty }
end 

allowLCC = true;
defaultCompInfo = coder.internal.DefaultCompInfo.createDefaultCompInfo(  );
modelCompInfo = coder.internal.ModelCompInfo.createModelCompInfo(  ...
model, defaultCompInfo.DefaultMexCompInfo, allowLCC );

result = Simulink.packagedmodel.getCoderCompilerFromCompInfo( modelCompInfo );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdtADjc.p.
% Please follow local copyright laws when handling this file.

