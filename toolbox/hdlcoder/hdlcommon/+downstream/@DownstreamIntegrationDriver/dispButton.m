function dispButton(obj)




    fprintf('\n');

    if~obj.isToolEmpty
        fprintf('   <a href="matlab:downstream.handle(''Model'',''%s'').openTargetTool;">Open %s</a>  ',obj.hCodeGen.ModelName,obj.get('Tool'));
    end
    fprintf('   <a href="matlab:get(downstream.handle(''Model'',''%s''));">GetOptions</a>  ',obj.hCodeGen.ModelName);
    fprintf('   <a href="matlab:set(downstream.handle(''Model'',''%s''));">SetOptions</a>  ',obj.hCodeGen.ModelName);
    fprintf('   <a href="matlab:downstream.handle(''Model'',''%s'').disp;">Status</a>  \n',obj.hCodeGen.ModelName);
    if obj.isTurnkeyWorkflow||obj.isXPCWorkflow
        fprintf('\n   <a href="matlab:downstream.handle(''Model'',''%s'').hTurnkey.hTable.drawCmdTable(true);">Populate Interface Table</a>  ',obj.hCodeGen.ModelName);
        fprintf('   <a href="matlab:downstream.handle(''Model'',''%s'').hTurnkey.hTable.drawCmdTable;">Get Target Interface</a>  ',obj.hCodeGen.ModelName);
        fprintf('   <a href="matlab:downstream.handle(''Model'',''%s'').hTurnkey.hTable.drawCmdTableSet;">Set Target Interface</a>  ',obj.hCodeGen.ModelName);
        fprintf('   <a href="matlab:downstream.handle(''Model'',''%s'').hTurnkey.hCHandle.makehdlturnkey;">Turnkey CodeGen</a>  \n',obj.hCodeGen.ModelName);
    end

    fprintf('\n-------------------------------------------------------------------\n');

end