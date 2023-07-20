function ReplaceElMath(block,h)





    if askToReplace(h,block)

        Op=get_param(block,'Operator');

        switch(Op)
        case{'sin','cos','tan','asin','acos','atan','atan2','sinh','cosh','tanh'}

            funcSet=uReplaceBlock(h,block,'built-in/Trigonometry','Operator',Op);
            appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});

        case{'exp','log','log10','sqrt','reciprocal','pow','hypot'}

            funcSet=uReplaceBlock(h,block,'built-in/Math','Operator',Op);
            appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});

        case{'floor','ceil'}

            funcSet=uReplaceBlock(h,block,'built-in/Rounding','Operator',Op);
            appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
        end
    end

end
