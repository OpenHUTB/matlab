// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   UpdateType.java

package com.mathworks.addons_common;


public class UpdateType extends Enum
{

    public static UpdateType[] values()
    {
        return (UpdateType[])$VALUES.clone();
    }

    public static UpdateType valueOf(String s)
    {
        return (UpdateType)Enum.valueOf(com/mathworks/addons_common/UpdateType, s);
    }

    private UpdateType(String s, int i)
    {
        super(s, i);
    }


    public static final UpdateType COMMUNITY;
    public static final UpdateType MATLAB;
    public static final UpdateType HARDWARE_SUPPORT;
    public static final UpdateType FEATURE;
    private static final UpdateType $VALUES[];

    static 
    {
        COMMUNITY = new UpdateType("COMMUNITY", 0) {

            public String toString()
            {
                return "community";
            }

        }
;
        MATLAB = new UpdateType("MATLAB", 1) {

            public String toString()
            {
                return "matlab";
            }

        }
;
        HARDWARE_SUPPORT = new UpdateType("HARDWARE_SUPPORT", 2) {

            public String toString()
            {
                return "hardware_support";
            }

        }
;
        FEATURE = new UpdateType("FEATURE", 3) {

            public String toString()
            {
                return "feature";
            }

        }
;
        $VALUES = (new UpdateType[] {
            COMMUNITY, MATLAB, HARDWARE_SUPPORT, FEATURE
        });
    }
}
