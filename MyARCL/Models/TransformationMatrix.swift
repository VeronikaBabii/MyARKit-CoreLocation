//
//  TransformationMatrix.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import CoreLocation
import GLKit

class TransformationMatrix {
    
    static func translateMatrix(_ matrix: matrix_float4x4, by translation: vector_float4) -> matrix_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    static func rotateYCoordinate(of matrix: matrix_float4x4, by degrees: Float) -> matrix_float4x4 {
        var matrix: matrix_float4x4 = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    static func transformCoordinates(initialLocation: CLLocation, location: CLLocation) -> simd_float4x4 {
        let matrix: simd_float4x4 = matrix_identity_float4x4
        
        let distanceToInitial = Float(location.distance(from: initialLocation))
        
        let bearing = Float(initialLocation.angleBetweenThisLocation(and: location))
        
        let translationVector = vector_float4(0.0, 0.0, -distanceToInitial, 0.0)
        
        let translationMatrix = translateMatrix(matrix_identity_float4x4, by: translationVector)
        let rotationMatrix = rotateYCoordinate(of: matrix_identity_float4x4, by: bearing)
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        return simd_mul(matrix, transformMatrix)
    }
}
