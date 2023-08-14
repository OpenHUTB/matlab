






function mapKey=getMisraCshMapKey()
    if Advisor.Utils.license('test','RTW_Embedded_Coder')
        mapKey='ma.ecoder';
    elseif Advisor.Utils.license('test','SL_Verification_Validation')
        mapKey='ma.misrac2012';
    else
        mapKey='';



    end
end

