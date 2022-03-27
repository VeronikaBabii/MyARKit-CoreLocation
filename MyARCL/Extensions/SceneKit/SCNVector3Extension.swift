//
//  SCNVector3Extension.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import SceneKit

extension SCNVector3 {
    static func transformVectorCoordinates(by matrix: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(matrix.columns.3.x,
                              matrix.columns.3.y,
                              matrix.columns.3.z)
    }
}
