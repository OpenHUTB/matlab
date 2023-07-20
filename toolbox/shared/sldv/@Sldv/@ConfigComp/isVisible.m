function result=isVisible(h)%#ok<INUSD>




    result=true;
    slavtexist=license('test','Simulink_Design_Verifier')&&exist('slavteng','builtin')==5;
    if slavtexist==0
        result=false;
    end
