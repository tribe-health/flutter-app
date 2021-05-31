import '../db/dao/jobs_dao.dart';
import '../db/mixin_database.dart';

extension JobsDaoExtension on JobsDao {
  Future<void> insertNoReplace(Job job) async {
    final exists = await findAckJobById(job.jobId);
    if (exists == null) {
      await insert(job);
    }
  }
}