function P=getPeriodogramMatrixAverage(obj)




    P=squeeze(sum(obj.pPeriodogramMatrix,2)/obj.pNumAvgsCounter);
end
