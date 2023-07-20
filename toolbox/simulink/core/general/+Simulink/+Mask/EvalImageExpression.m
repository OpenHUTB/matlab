



function cellResult=EvalImageExpression(obj,lineExpression)
    MTreeObj=mtree(char(lineExpression));
    MTreeObj=MTreeObj.setIX(1);
    if((MTreeObj.iskind('EXPR')||MTreeObj.iskind('PRINT'))&&...
        MTreeObj.Arg.iskind('CALL')&&...
        strcmp(tree2str(MTreeObj.Arg.Left),'imread'))
        MTreeArg=MTreeObj.Arg.Right;
        Arguments='';
        while(~isnull(MTreeArg))
            Arguments=[Arguments,tree2str(MTreeArg)];
            MTreeArg=MTreeArg.Next;
            if(~isnull(MTreeArg))
                Arguments=[Arguments,','];
            end
        end
        ImageFileName=obj.EvalExpression(Arguments);
        ImageFileName=ImageFileName{1};
        MTreeObj=MTreeObj.Next;
        cellResult=obj.EvalExpression(['''',ImageFileName,''',',tree2str(MTreeObj)]);
    else
        cellResult=obj.EvalExpression(lineExpression);
    end
end