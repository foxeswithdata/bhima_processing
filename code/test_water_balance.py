import numpy



transpiration = 0.0012252802547415675
w = numpy.array([0.00562226, 0.01115039, 0.01650165, 0.03394673, 0.04535822, 0.11386721])
wres = numpy.array([0.00562226, 0.01115039, 0.01650165, 0.03394673, 0.04535822, 0.11386721])
total_water_by_layer = numpy.array([0.00000000e+00, 1.73472348e-18, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00, 0.00000000e+00])
# print("PF input data " + str(plantFATE_data))
# print("Total Available Water " + str(sum(total_water_by_layer)))
# print("Water we are taking " + str(transpiration))
if transpiration > sum(total_water_by_layer):
    print("Old transpiration: " + str(transpiration))
    transpiration = min(transpiration, sum(total_water_by_layer))
    print("New transpiration: " + str(transpiration))
    print("water by layer " + str(total_water_by_layer))
    print("water by layer w " + str(w))
    print("water by layer wres " + str(wres))

plantfate_transpiration = transpiration
plantfate_transpiration_by_layer = [0, 0, 0, 0, 0, 0]
total_water = w.sum() - wres.sum()
N_SOIL_LAYERS = 6
print(total_water)
for layer in range(N_SOIL_LAYERS):
    print(layer)
    plantfate_transpiration_by_layer[layer] = plantfate_transpiration * (
                total_water_by_layer[layer] / total_water_by_layer.sum())
    print(plantfate_transpiration_by_layer)
