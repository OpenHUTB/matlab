function adf=automlMotoLngadf(Ffs,Ffwext_x,Ffwext_z,Flfext_x,Flfext_z,Fmext_x,Fmext_z,Fraext_x,Fraext_z,Frwext_x,Frwext_z,Fufext_x,Fufext_z,Fxext,Fxf,Fxr,Fzext,Fzf,Fzr,amu,amur,lf,lm,lr,mfw,mlf,mm,mra,mrw,muf,pCGxm,pCGzm,pCGxlf,pCGxra,pCGzlf,pCGzra,pCGxuf,pCGzuf,pdf,pmu,pmur,rmu,rmur)
%#codegen
    coder.allowpcode('plain')







    t2=cos(pmu);
    t3=sin(pmu);
    t4=pmu+pmur;
    t5=rmu.^2;
    t6=rmur.^2;
    t7=cos(t4);
    t8=sin(t4);
    et1=Ffs.*mfw+Ffs.*mlf+Ffs.*mm+Ffs.*mra+Ffs.*mrw+Ffs.*muf+Ffwext_x.*mm.*t8+Ffwext_z.*mm.*t7-Fmext_x.*mfw.*t8-Fmext_z.*mfw.*t7+Ffwext_x.*mra.*t8-Fraext_x.*mfw.*t8+Ffwext_z.*mra.*t7-Fraext_z.*mfw.*t7+Ffwext_x.*mrw.*t8-Frwext_x.*mfw.*t8+Ffwext_z.*mrw.*t7-Frwext_z.*mfw.*t7+Flfext_x.*mm.*t8+Flfext_z.*mm.*t7-Fmext_x.*mlf.*t8-Fmext_z.*mlf.*t7+Ffwext_x.*muf.*t8-Fufext_x.*mfw.*t8+Ffwext_z.*muf.*t7-Fufext_z.*mfw.*t7+Flfext_x.*mra.*t8-Fraext_x.*mlf.*t8+Flfext_z.*mra.*t7-Fraext_z.*mlf.*t7-Fxext.*mfw.*t8+Flfext_x.*mrw.*t8-Frwext_x.*mlf.*t8+Flfext_z.*mrw.*t7-Frwext_z.*mlf.*t7-Fxr.*mfw.*t8-Fzext.*mfw.*t7-Fzr.*mfw.*t7+Flfext_x.*muf.*t8-Fufext_x.*mlf.*t8+Flfext_z.*muf.*t7;
    et2=-Fufext_z.*mlf.*t7-Fxext.*mlf.*t8-Fxr.*mlf.*t8+Fxf.*mm.*t8-Fzext.*mlf.*t7-Fzr.*mlf.*t7+Fzf.*mm.*t7+Fxf.*mra.*t8+Fxf.*mrw.*t8+Fzf.*mra.*t7+Fzf.*mrw.*t7+Fxf.*muf.*t8+Fzf.*muf.*t7+amu.*lf.*mfw.*mm+amur.*lf.*mfw.*mm+amu.*lf.*mfw.*mra+amur.*lf.*mfw.*mra+amu.*lf.*mfw.*mrw+amur.*lf.*mfw.*mrw+amu.*lm.*mfw.*mm+amur.*lm.*mfw.*mm+amu.*lf.*mfw.*muf+amur.*lf.*mfw.*muf+amu.*lm.*mfw.*mra+amur.*lm.*mfw.*mra+amu.*lm.*mfw.*mrw+amur.*lm.*mfw.*mrw+amu.*lm.*mlf.*mm+amur.*lm.*mlf.*mm+amu.*lm.*mlf.*mra+amur.*lm.*mlf.*mra+amu.*lm.*mlf.*mrw+amur.*lm.*mlf.*mrw-amu.*mfw.*mm.*pCGxm-amur.*mfw.*mm.*pCGxm-amu.*mlf.*mm.*pCGxm+amu.*mlf.*mm.*pCGxlf-amur.*mlf.*mm.*pCGxm+amur.*mlf.*mm.*pCGxlf;
    et3=-amu.*mfw.*muf.*pCGxuf-amur.*mfw.*muf.*pCGxuf+amu.*mlf.*mra.*pCGxlf+amur.*mlf.*mra.*pCGxlf+amu.*mlf.*mrw.*pCGxlf+amur.*mlf.*mrw.*pCGxlf+amu.*mlf.*muf.*pCGxlf-amu.*mlf.*muf.*pCGxuf+amur.*mlf.*muf.*pCGxlf-amur.*mlf.*muf.*pCGxuf-mfw.*mm.*pCGzm.*t5-mfw.*mm.*pCGzm.*t6-mlf.*mm.*pCGzm.*t5-mlf.*mm.*pCGzm.*t6+mlf.*mm.*pCGzlf.*t5+mlf.*mm.*pCGzlf.*t6-mfw.*muf.*pCGzuf.*t5-mfw.*muf.*pCGzuf.*t6+mlf.*mra.*pCGzlf.*t5+mlf.*mra.*pCGzlf.*t6+mlf.*mrw.*pCGzlf.*t5+mlf.*mrw.*pCGzlf.*t6+mlf.*muf.*pCGzlf.*t5+mlf.*muf.*pCGzlf.*t6-mlf.*muf.*pCGzuf.*t5-mlf.*muf.*pCGzuf.*t6+mfw.*mm.*pdf.*t5+mfw.*mm.*pdf.*t6+mfw.*mra.*pdf.*t5+mfw.*mra.*pdf.*t6+mfw.*mrw.*pdf.*t5+mfw.*mrw.*pdf.*t6+mlf.*mm.*pdf.*t5+mlf.*mm.*pdf.*t6+mfw.*muf.*pdf.*t5;
    et4=mfw.*muf.*pdf.*t6+mlf.*mra.*pdf.*t5+mlf.*mra.*pdf.*t6+mlf.*mrw.*pdf.*t5+mlf.*mrw.*pdf.*t6+mlf.*muf.*pdf.*t5+mlf.*muf.*pdf.*t6+amur.*lr.*mfw.*mra.*t2+amur.*lr.*mfw.*mrw.*t2+amur.*lr.*mlf.*mra.*t2+amur.*lr.*mlf.*mrw.*t2-amur.*mfw.*mra.*pCGxra.*t2+amur.*mfw.*mra.*pCGzra.*t3-amur.*mlf.*mra.*pCGxra.*t2+amur.*mlf.*mra.*pCGzra.*t3+lr.*mfw.*mra.*t3.*t6+lr.*mfw.*mrw.*t3.*t6+lr.*mlf.*mra.*t3.*t6+lr.*mlf.*mrw.*t3.*t6-mfw.*mm.*pCGzm.*rmu.*rmur.*2.0-mlf.*mm.*pCGzm.*rmu.*rmur.*2.0+mlf.*mm.*pCGzlf.*rmu.*rmur.*2.0-mfw.*muf.*pCGzuf.*rmu.*rmur.*2.0+mlf.*mra.*pCGzlf.*rmu.*rmur.*2.0+mlf.*mrw.*pCGzlf.*rmu.*rmur.*2.0+mlf.*muf.*pCGzlf.*rmu.*rmur.*2.0-mlf.*muf.*pCGzuf.*rmu.*rmur.*2.0+mfw.*mm.*pdf.*rmu.*rmur.*2.0+mfw.*mra.*pdf.*rmu.*rmur.*2.0+mfw.*mrw.*pdf.*rmu.*rmur.*2.0+mlf.*mm.*pdf.*rmu.*rmur.*2.0;
    et5=mfw.*muf.*pdf.*rmu.*rmur.*2.0+mlf.*mra.*pdf.*rmu.*rmur.*2.0+mlf.*mrw.*pdf.*rmu.*rmur.*2.0+mlf.*muf.*pdf.*rmu.*rmur.*2.0-mfw.*mra.*pCGxra.*t3.*t6-mfw.*mra.*pCGzra.*t2.*t6-mlf.*mra.*pCGxra.*t3.*t6-mlf.*mra.*pCGzra.*t2.*t6;
    adf=(et1+et2+et3+et4+et5)./((mfw+mlf).*(mm+mra+mrw+muf));

end
