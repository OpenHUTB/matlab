function matrixModelElement=toDependencyMatrixModel(model,zcModelName)









    txn=model.beginTransaction();


    zcModel=systemcomposer.loadModel(zcModelName);


    matrixModel=systemcomposer.internal.matrix.DependencyMatrixModel(model);
    matrixModelElement=matrixModel.toDependencyMatrixModel('Dependency Matrix',zcModel);


    matrixModelElement.p_MatrixSize=systemcomposer.syntax.matrix.Size;
    matrixModelElement.p_MatrixSize.p_Width=1500;
    matrixModelElement.p_MatrixSize.p_Height=900;
    matrixModelElement.p_RowHeaderSize=systemcomposer.syntax.matrix.Size;
    matrixModelElement.p_RowHeaderSize.p_Width=0;
    matrixModelElement.p_RowHeaderSize.p_Height=0;
    matrixModelElement.p_ColumnHeaderSize=systemcomposer.syntax.matrix.Size;
    matrixModelElement.p_ColumnHeaderSize.p_Width=0;
    matrixModelElement.p_ColumnHeaderSize.p_Height=0;


    txn.commit();
end
