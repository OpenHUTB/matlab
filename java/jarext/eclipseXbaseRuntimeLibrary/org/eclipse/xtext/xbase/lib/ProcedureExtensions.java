// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ProcedureExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            Procedures

public class ProcedureExtensions
{

    public ProcedureExtensions()
    {
    }

    public static Procedures.Procedure0 curry(Procedures.Procedure1 procedure, Object argument)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        else
            return new Procedures.Procedure0(procedure, argument) {

                public void apply()
                {
                    procedure.apply(argument);
                }

                final Procedures.Procedure1 val$procedure;
                final Object val$argument;

            
            {
                procedure = procedure1;
                argument = obj;
                super();
            }
            }
;
    }

    public static Procedures.Procedure1 curry(Procedures.Procedure2 procedure, Object argument)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        else
            return new Procedures.Procedure1(procedure, argument) {

                public void apply(Object p)
                {
                    procedure.apply(argument, p);
                }

                final Procedures.Procedure2 val$procedure;
                final Object val$argument;

            
            {
                procedure = procedure2;
                argument = obj;
                super();
            }
            }
;
    }

    public static Procedures.Procedure2 curry(Procedures.Procedure3 procedure, Object argument)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        else
            return new Procedures.Procedure2(procedure, argument) {

                public void apply(Object p2, Object p3)
                {
                    procedure.apply(argument, p2, p3);
                }

                final Procedures.Procedure3 val$procedure;
                final Object val$argument;

            
            {
                procedure = procedure3;
                argument = obj;
                super();
            }
            }
;
    }

    public static Procedures.Procedure3 curry(Procedures.Procedure4 procedure, Object argument)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        else
            return new Procedures.Procedure3(procedure, argument) {

                public void apply(Object p2, Object p3, Object p4)
                {
                    procedure.apply(argument, p2, p3, p4);
                }

                final Procedures.Procedure4 val$procedure;
                final Object val$argument;

            
            {
                procedure = procedure4;
                argument = obj;
                super();
            }
            }
;
    }

    public static Procedures.Procedure4 curry(Procedures.Procedure5 procedure, Object argument)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        else
            return new Procedures.Procedure4(procedure, argument) {

                public void apply(Object p2, Object p3, Object p4, Object p5)
                {
                    procedure.apply(argument, p2, p3, p4, p5);
                }

                final Procedures.Procedure5 val$procedure;
                final Object val$argument;

            
            {
                procedure = procedure5;
                argument = obj;
                super();
            }
            }
;
    }

    public static Procedures.Procedure5 curry(Procedures.Procedure6 procedure, Object argument)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        else
            return new Procedures.Procedure5(procedure, argument) {

                public void apply(Object p2, Object p3, Object p4, Object p5, Object p6)
                {
                    procedure.apply(argument, p2, p3, p4, p5, p6);
                }

                final Procedures.Procedure6 val$procedure;
                final Object val$argument;

            
            {
                procedure = procedure6;
                argument = obj;
                super();
            }
            }
;
    }
}
