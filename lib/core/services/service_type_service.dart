import '../constants/branches.dart';
import '../constants/service_types.dart';

class ServiceTypeService {
  static List<String> getServicesForBranch(String branchId) {

    List<String> services = [
      ...ServiceTypes.generalServices,
    ];

    if (branchId == Branches.hq) {
      services.insertAll(
        3,
        ServiceTypes.conventionServices,
      );
    }

    return services;
  }
}