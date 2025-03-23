// Get all students
export const getAllStudents = async (req, res, next) => {
    try {
        const db = req.app.locals.db;
        const [rows] = await db.query('SELECT * FROM students');

        res.status(200).json(rows);
    } catch (error) {
        next(error);
    }
};

// Get a student by ID
export const getStudentById = async (req, res, next) => {
    try {
        const db = req.app.locals.db;
        const [rows] = await db.query('SELECT * FROM students WHERE id = ?', [req.params.id]);

        if (rows.length === 0) {
            return res.status(404).json({
                status: 'fail',
                message: 'Student not found'
            });
        }

        res.status(200).json(rows[0]);
    } catch (error) {
        next(error);
    }
};

// Create a new student
export const createStudent = async (req, res, next) => {
    try {
        const { first_name, last_name, age } = req.body;

        if (!first_name || !last_name || !age) {
            return res.status(400).json({
                status: 'fail',
                message: 'Please provide first_name, last_name, and age'
            });
        }

        const db = req.app.locals.db;
        const [result] = await db.query(
            'INSERT INTO students (first_name, last_name, age) VALUES (?, ?, ?)',
            [first_name, last_name, age]
        );

        const [newStudent] = await db.query('SELECT * FROM students WHERE id = ?', [result.insertId]);

        res.status(201).json({
            status: 'success',
            data: {
                student: newStudent[0]
            }
        });
    } catch (error) {
        next(error);
    }
};

// Update a student
export const updateStudent = async (req, res, next) => {
    try {
        const { first_name, last_name, age } = req.body;
        const { id } = req.params;

        const db = req.app.locals.db;

        // Check if student exists
        const [student] = await db.query('SELECT * FROM students WHERE id = ?', [id]);
        if (student.length === 0) {
            return res.status(404).json({
                status: 'fail',
                message: 'Student not found'
            });
        }

        // Build the update query dynamically based on provided fields
        const updates = [];
        const values = [];

        if (first_name !== undefined) {
            updates.push('first_name = ?');
            values.push(first_name);
        }

        if (last_name !== undefined) {
            updates.push('last_name = ?');
            values.push(last_name);
        }

        if (age !== undefined) {
            updates.push('age = ?');
            values.push(age);
        }

        if (updates.length === 0) {
            return res.status(400).json({
                status: 'fail',
                message: 'No fields to update'
            });
        }

        values.push(id);

        await db.query(
            `UPDATE students SET ${updates.join(', ')} WHERE id = ?`,
            values
        );

        const [updatedStudent] = await db.query('SELECT * FROM students WHERE id = ?', [id]);

        res.status(200).json({
            status: 'success',
            data: {
                student: updatedStudent[0]
            }
        });
    } catch (error) {
        next(error);
    }
};

// Delete a student
export const deleteStudent = async (req, res, next) => {
    try {
        const db = req.app.locals.db;
        const { id } = req.params;

        // Check if student exists
        const [student] = await db.query('SELECT * FROM students WHERE id = ?', [id]);
        if (student.length === 0) {
            return res.status(404).json({
                status: 'fail',
                message: 'Student not found'
            });
        }

        await db.query('DELETE FROM students WHERE id = ?', [id]);

        res.status(200).json({
            status: 'success',
            data: null
        });
    } catch (error) {
        next(error);
    }
};
