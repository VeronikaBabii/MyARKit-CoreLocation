//
//  SCNVector3Ext.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import SceneKit

extension SCNVector3 {
    
    static func transCoordinates(_ transform: matrix_float4x4) -> SCNVector3 {
        
        return SCNVector3Make(transform.columns.3.x,
                              transform.columns.3.y,
                              transform.columns.3.z)
    }
}
