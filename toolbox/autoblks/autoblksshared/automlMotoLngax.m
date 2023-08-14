function ax=automlMotoLngax(Ffwext_x,Flfext_x,Fmext_x,Fraext_x,Frwext_x,Fufext_x,Fxext,Fxf,Fxr,adf,amu,amur,lf,lm,lr,mfw,mlf,mm,mra,mrw,muf,pCGxm,pCGzm,pCGxlf,pCGxra,pCGzlf,pCGzra,pCGxuf,pCGzuf,pdf,pmu,pmur,rdf,rmu,rmur)

%#codegen
    coder.allowpcode('plain')







    t2=cos(pmu);
    t3=cos(pmur);
    t4=sin(pmu);
    t5=sin(pmur);
    t6=rmu.^2;
    t7=rmur.^2;
    et1=Ffwext_x+Flfext_x+Fmext_x+Fraext_x+Frwext_x+Fufext_x+Fxext+Fxf+Fxr+amur.*lr.*mfw.*t5+amur.*lr.*mlf.*t5+amur.*lr.*mm.*t5+amur.*lr.*muf.*t5+amur.*mra.*pCGxra.*t5-amur.*mra.*pCGzra.*t3-adf.*mfw.*t2.*t5-adf.*mfw.*t3.*t4-adf.*mlf.*t2.*t5-adf.*mlf.*t3.*t4+lr.*mfw.*t3.*t7+lr.*mlf.*t3.*t7+lr.*mm.*t3.*t7+lr.*muf.*t3.*t7+mra.*pCGxra.*t3.*t7+mra.*pCGzra.*t5.*t7+amu.*lf.*mfw.*t2.*t5+amu.*lf.*mfw.*t3.*t4+amur.*lf.*mfw.*t2.*t5+amur.*lf.*mfw.*t3.*t4+amu.*lm.*mfw.*t2.*t5+amu.*lm.*mfw.*t3.*t4+amur.*lm.*mfw.*t2.*t5+amur.*lm.*mfw.*t3.*t4+amu.*lm.*mlf.*t2.*t5+amu.*lm.*mlf.*t3.*t4+amur.*lm.*mlf.*t2.*t5+amur.*lm.*mlf.*t3.*t4+amu.*lm.*muf.*t2.*t5+amu.*lm.*muf.*t3.*t4+amur.*lm.*muf.*t2.*t5+amur.*lm.*muf.*t3.*t4;
    et2=amu.*mlf.*pCGxlf.*t2.*t5+amu.*mlf.*pCGxlf.*t3.*t4-amu.*mlf.*pCGzlf.*t2.*t3+amu.*mlf.*pCGzlf.*t4.*t5+amur.*mlf.*pCGxlf.*t2.*t5+amur.*mlf.*pCGxlf.*t3.*t4-amur.*mlf.*pCGzlf.*t2.*t3+amur.*mlf.*pCGzlf.*t4.*t5+amu.*mm.*pCGxm.*t2.*t5+amu.*mm.*pCGxm.*t3.*t4-amu.*mm.*pCGzm.*t2.*t3+amu.*mm.*pCGzm.*t4.*t5+amur.*mm.*pCGxm.*t2.*t5+amur.*mm.*pCGxm.*t3.*t4-amur.*mm.*pCGzm.*t2.*t3+amur.*mm.*pCGzm.*t4.*t5+amu.*muf.*pCGxuf.*t2.*t5+amu.*muf.*pCGxuf.*t3.*t4-amu.*muf.*pCGzuf.*t2.*t3+amu.*muf.*pCGzuf.*t4.*t5+amur.*muf.*pCGxuf.*t2.*t5+amur.*muf.*pCGxuf.*t3.*t4-amur.*muf.*pCGzuf.*t2.*t3+amur.*muf.*pCGzuf.*t4.*t5-amu.*mfw.*pdf.*t2.*t3+amu.*mfw.*pdf.*t4.*t5-amur.*mfw.*pdf.*t2.*t3+amur.*mfw.*pdf.*t4.*t5-amu.*mlf.*pdf.*t2.*t3+amu.*mlf.*pdf.*t4.*t5;
    et3=-amur.*mlf.*pdf.*t2.*t3+amur.*mlf.*pdf.*t4.*t5+lf.*mfw.*t2.*t3.*t6+lf.*mfw.*t2.*t3.*t7-lf.*mfw.*t4.*t5.*t6-lf.*mfw.*t4.*t5.*t7+lm.*mfw.*t2.*t3.*t6+lm.*mfw.*t2.*t3.*t7-lm.*mfw.*t4.*t5.*t6-lm.*mfw.*t4.*t5.*t7+lm.*mlf.*t2.*t3.*t6+lm.*mlf.*t2.*t3.*t7-lm.*mlf.*t4.*t5.*t6-lm.*mlf.*t4.*t5.*t7+lm.*muf.*t2.*t3.*t6+lm.*muf.*t2.*t3.*t7-lm.*muf.*t4.*t5.*t6-lm.*muf.*t4.*t5.*t7+mlf.*pCGxlf.*t2.*t3.*t6+mlf.*pCGxlf.*t2.*t3.*t7-mlf.*pCGxlf.*t4.*t5.*t6+mlf.*pCGzlf.*t2.*t5.*t6+mlf.*pCGzlf.*t3.*t4.*t6-mlf.*pCGxlf.*t4.*t5.*t7+mlf.*pCGzlf.*t2.*t5.*t7+mlf.*pCGzlf.*t3.*t4.*t7+mm.*pCGxm.*t2.*t3.*t6+mm.*pCGxm.*t2.*t3.*t7-mm.*pCGxm.*t4.*t5.*t6;
    et4=mm.*pCGzm.*t2.*t5.*t6+mm.*pCGzm.*t3.*t4.*t6-mm.*pCGxm.*t4.*t5.*t7+mm.*pCGzm.*t2.*t5.*t7+mm.*pCGzm.*t3.*t4.*t7+muf.*pCGxuf.*t2.*t3.*t6+muf.*pCGxuf.*t2.*t3.*t7-muf.*pCGxuf.*t4.*t5.*t6+muf.*pCGzuf.*t2.*t5.*t6+muf.*pCGzuf.*t3.*t4.*t6-muf.*pCGxuf.*t4.*t5.*t7+muf.*pCGzuf.*t2.*t5.*t7+muf.*pCGzuf.*t3.*t4.*t7+mfw.*pdf.*t2.*t5.*t6+mfw.*pdf.*t3.*t4.*t6+mfw.*pdf.*t2.*t5.*t7+mfw.*pdf.*t3.*t4.*t7+mlf.*pdf.*t2.*t5.*t6+mlf.*pdf.*t3.*t4.*t6+mlf.*pdf.*t2.*t5.*t7+mlf.*pdf.*t3.*t4.*t7-mfw.*rdf.*rmu.*t2.*t3.*2.0+mfw.*rdf.*rmu.*t4.*t5.*2.0-mfw.*rdf.*rmur.*t2.*t3.*2.0+mfw.*rdf.*rmur.*t4.*t5.*2.0-mlf.*rdf.*rmu.*t2.*t3.*2.0+mlf.*rdf.*rmu.*t4.*t5.*2.0-mlf.*rdf.*rmur.*t2.*t3.*2.0+mlf.*rdf.*rmur.*t4.*t5.*2.0+lf.*mfw.*rmu.*rmur.*t2.*t3.*2.0;
    et5=lf.*mfw.*rmu.*rmur.*t4.*t5.*-2.0+lm.*mfw.*rmu.*rmur.*t2.*t3.*2.0-lm.*mfw.*rmu.*rmur.*t4.*t5.*2.0+lm.*mlf.*rmu.*rmur.*t2.*t3.*2.0-lm.*mlf.*rmu.*rmur.*t4.*t5.*2.0+lm.*muf.*rmu.*rmur.*t2.*t3.*2.0-lm.*muf.*rmu.*rmur.*t4.*t5.*2.0+mlf.*pCGxlf.*rmu.*rmur.*t2.*t3.*2.0-mlf.*pCGxlf.*rmu.*rmur.*t4.*t5.*2.0+mlf.*pCGzlf.*rmu.*rmur.*t2.*t5.*2.0+mlf.*pCGzlf.*rmu.*rmur.*t3.*t4.*2.0+mm.*pCGxm.*rmu.*rmur.*t2.*t3.*2.0-mm.*pCGxm.*rmu.*rmur.*t4.*t5.*2.0+mm.*pCGzm.*rmu.*rmur.*t2.*t5.*2.0+mm.*pCGzm.*rmu.*rmur.*t3.*t4.*2.0+muf.*pCGxuf.*rmu.*rmur.*t2.*t3.*2.0-muf.*pCGxuf.*rmu.*rmur.*t4.*t5.*2.0+muf.*pCGzuf.*rmu.*rmur.*t2.*t5.*2.0+muf.*pCGzuf.*rmu.*rmur.*t3.*t4.*2.0+mfw.*pdf.*rmu.*rmur.*t2.*t5.*2.0+mfw.*pdf.*rmu.*rmur.*t3.*t4.*2.0+mlf.*pdf.*rmu.*rmur.*t2.*t5.*2.0+mlf.*pdf.*rmu.*rmur.*t3.*t4.*2.0;
    ax=(et1+et2+et3+et4+et5)./(mfw+mlf+mm+mra+mrw+muf);

end