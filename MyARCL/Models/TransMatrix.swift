//
//  TransMatrix.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import CoreLocation
import GLKit

class TransMatrix {
    
    static func translationMatrix(matrix: matrix_float4x4, translation: vector_float4) -> matrix_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    static func rotateYCoord(matrix: matrix_float4x4, degrees: Float) -> matrix_float4x4 {
        var matrix: matrix_float4x4 = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    static func transformCoordinates(startLoc: CLLocation, location: CLLocation) -> simd_float4x4 {
        
        let matrix: simd_float4x4 = matrix_identity_float4x4
        
        let distanceToStart = Float(location.distance(from: startLoc))
        
        let bearing = startLoc.angleToLoc(location)
        
        let pos = vector_float4(0.0, 0.0, -distanceToStart, 0.0)
        
        let translationMatrix = self.translationMatrix(matrix: matrix_identity_float4x4, translation: pos)
        let rotationMatrix = self.rotateYCoord(matrix: matrix_identity_float4x4, degrees: Float(bearing))
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        return simd_mul(matrix, transformMatrix)
    }
}
